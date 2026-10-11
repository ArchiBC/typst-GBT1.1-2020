"""Remove regenerable build reports and previews; keep sources and deliverables."""
import argparse
import json
import os
from pathlib import Path
import shutil
import stat
import subprocess

ROOT = Path(__file__).absolute().parents[1]
REPARSE_POINT = getattr(stat, 'FILE_ATTRIBUTE_REPARSE_POINT', 0x400)


def checked(path):
    """Reject links before resolving or traversing any cleanup target."""
    for parent in (path, *path.parents):
        if not parent.is_relative_to(ROOT):
            break
        if parent.exists() or parent.is_symlink():
            attributes = getattr(parent.lstat(), 'st_file_attributes', 0)
            if parent.is_symlink() or attributes & REPARSE_POINT:
                raise ValueError(f'Refusing linked cleanup path: {parent}')
    resolved = path.resolve()
    if resolved == ROOT.resolve() or not resolved.is_relative_to(ROOT.resolve()):
        raise ValueError(f'Cleanup target is outside the project: {path}')
    return resolved


def inspect(path):
    checked(path)
    if path.is_file():
        return path.stat().st_size, 1
    size = count = 0
    for directory, folders, files in os.walk(path, followlinks=False):
        for name in (*folders, *files):
            child = Path(directory) / name
            checked(child)
            if child.is_file():
                size += child.stat().st_size
                count += 1
    return size, count


def targets():
    # Check output before globbing so a linked directory is never traversed.
    for folder in ('output', 'tools'):
        checked(ROOT / folder)
    candidates = [ROOT / name for name in ('output/tmp', 'output/qa',
                                         'tools/__pycache__',
                                         'output/typst-gbt-1.1-2020.zip')]
    candidates.extend((ROOT / 'output').glob('*.json'))
    return sorted(set(path for path in candidates if path.exists() or path.is_symlink()))


def remove(paths):
    if os.name == 'nt':
        # Fixed PowerShell code receives data through an environment variable.
        # Validate every literal path in the same shell that removes it.
        script = r'''
$ErrorActionPreference = 'Stop'
$plan = ConvertFrom-Json $env:GBT_CLEAN_PLAN
$root = [IO.Path]::GetFullPath($plan.root).TrimEnd('\')
foreach ($target in $plan.paths) {
    $full = [IO.Path]::GetFullPath($target)
    if (-not $full.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw "Cleanup target is outside the project: $full"
    }
    $current = Get-Item -LiteralPath $full -Force
    while ($null -ne $current -and $current.FullName.Length -ge $root.Length) {
        if ($current.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "Refusing linked cleanup path: $($current.FullName)"
        }
        $current = if ($current -is [IO.DirectoryInfo]) { $current.Parent } else { $current.Directory }
    }
    if (Test-Path -LiteralPath $full -PathType Container) {
        foreach ($item in Get-ChildItem -LiteralPath $full -Force -Recurse) {
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                throw "Refusing linked cleanup path: $($item.FullName)"
            }
        }
    }
}
foreach ($target in $plan.paths) {
    Remove-Item -LiteralPath $target -Force -Recurse
}
'''
        env = dict(os.environ)
        env['GBT_CLEAN_PLAN'] = json.dumps({'root': str(ROOT.resolve()),
                                          'paths': [str(path) for path in paths]})
        subprocess.run(['powershell', '-NoProfile', '-NonInteractive', '-Command', script],
                       env=env, check=True)
    else:
        for path in paths:
            checked(path)
            if path.is_dir():
                shutil.rmtree(path)
            else:
                path.unlink()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dry-run', action='store_true', help='Print the plan without removing files.')
    args = parser.parse_args()
    paths = targets()
    plan = []
    for path in paths:
        size, files = inspect(path)
        plan.append({'path': path.relative_to(ROOT).as_posix(), 'bytes': size, 'files': files})
    print(json.dumps({'dry_run': args.dry_run, 'targets': plan,
                      'bytes': sum(item['bytes'] for item in plan)}, indent=2), flush=True)
    if not args.dry_run and paths:
        remove([checked(path) for path in paths])
        print(f'Removed {len(paths)} regenerable targets.', flush=True)


if __name__ == '__main__':
    main()

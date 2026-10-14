"""Compile with the project's isolated Typst binding or an existing Typst CLI."""
import argparse
import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.tools' / 'python'))
REFERENCE_FONTS = Path(os.environ.get('GBT_REFERENCE_FONTS', ROOT/'fonts/reference'))
ROMAN_FONTS = Path(os.environ.get('GBT_ROMAN_FONTS', Path(os.environ.get('WINDIR', 'C:/Windows'))/'Fonts'))
CONSTRUCTION_FONTS = Path(os.environ.get('GBT_CONSTRUCTION_FONTS', Path(os.environ.get('WINDIR', 'C:/Windows'))/'Fonts'))

def construction_fonts(profile=None):
    names=('simsun.ttc','simhei.ttf','times.ttf','timesbd.ttf','timesi.ttf','timesbi.ttf')
    available = all((CONSTRUCTION_FONTS/name).is_file() for name in names)
    profile = profile or ('windows' if available else 'open')
    if profile not in ('windows','open'):
        raise ValueError('construction font profile must be windows or open')
    if profile == 'windows' and not available:
        raise ValueError('工程规范参考字体不可用；使用 open 配置，或设置 GBT_CONSTRUCTION_FONTS。')
    if profile == 'open':return profile,()
    # Typst accepts font directories. Loading the whole Windows directory also
    # changes fallback in unrelated documents (e.g. Chinese code becomes LiSu).
    # Cache just the six selected files locally; .tools is never packaged.
    sources=[CONSTRUCTION_FONTS/name for name in names]
    signature='\n'.join(f'{p.resolve()}:{p.stat().st_size}:{p.stat().st_mtime_ns}' for p in sources)
    folder=ROOT/'.tools/construction-fonts'/hashlib.sha256(signature.encode()).hexdigest()[:16]
    assert folder.resolve().is_relative_to(ROOT.resolve())
    folder.mkdir(parents=True,exist_ok=True)
    for source in sources:
        target=folder/source.name
        assert not target.is_symlink()
        if not target.exists() or target.stat().st_size!=source.stat().st_size or target.stat().st_mtime_ns!=source.stat().st_mtime_ns:
            shutil.copy2(source,target)
    return profile,(folder,)

def compile_file(source, destination, extra_fonts=(), profile=None, inputs=None, construction_profile=None):
    source=Path(source)
    if profile is None:
        profile = 'open'
    if profile not in ('open', 'reference'):
        raise ValueError('font profile must be open or reference')
    if profile == 'reference':
        assert REFERENCE_FONTS.is_dir(), '参考字体目录不存在；指定开源 profile 编译，或设置 GBT_REFERENCE_FONTS 环境变量。'
        extra_fonts = (*extra_fonts, REFERENCE_FONTS, ROMAN_FONTS)
    destination.parent.mkdir(parents=True, exist_ok=True)
    construction_profile, construction_paths = construction_fonts(
        (inputs or {}).get('construction-font-profile',construction_profile or 'open'))
    extra_fonts = (*extra_fonts,*construction_paths)
    sys_inputs={**(inputs or {}),'font-profile':profile,'construction-font-profile':construction_profile}
    executable = ROOT / '.tools' / 'typst.exe'
    cli = str(executable) if executable.exists() else shutil.which('typst')
    if cli:
        subprocess.run([cli, 'compile', '--root', str(ROOT), '--font-path', str(ROOT / 'fonts'),
                        *[arg for p in extra_fonts for arg in ('--font-path', str(p))],
                        *[arg for key,value in sys_inputs.items() for arg in ('--input',key+'='+value)],
                        '--ignore-system-fonts', str(source), str(destination)], check=True)
    else:
        try:
            import typst
        except ImportError as exc:
            raise SystemExit('Install Typst CLI, or run tools/setup.ps1 to prepare the Python compiler.') from exc
        try:
            typst.compile(str(source), output=str(destination), root=str(ROOT),
                          font_paths=[str(ROOT / 'fonts'), *map(str, extra_fonts)], ignore_system_fonts=True,
                          sys_inputs=sys_inputs)
        except typst.TypstError as exc:
            raise SystemExit(exc.diagnostic) from exc
    print(f'compiled {destination.relative_to(ROOT)}', flush=True)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('source', nargs='?')
    parser.add_argument('destination', nargs='?')
    parser.add_argument('--font-profile', choices=('open','reference'))
    parser.add_argument('--construction-font-profile', choices=('open','windows'))
    parser.add_argument('--input', action='append', default=[], metavar='KEY=VALUE')
    args = parser.parse_args()
    if any('=' not in value for value in args.input):
        parser.error('--input 需要 KEY=VALUE。')
    inputs=dict(value.split('=',1) for value in args.input)
    if args.source:
        source = ROOT / args.source
        output = ROOT / args.destination if args.destination else ROOT / 'output' / 'pdf' / (source.stem + '.pdf')
        compile_file(source, output, profile=args.font_profile, inputs=inputs,
                     construction_profile=args.construction_font_profile)
    else:
        if inputs:parser.error('--input 需要指定待编译源文件。')
        from build import build
        build(profiles=(args.font_profile or 'open',),construction_profile=args.construction_font_profile)

if __name__ == '__main__':
    main()

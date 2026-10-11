"""Download the pinned OFL fonts and verify existing as well as new files."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import tarfile
import time
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
FONTS = ROOT / 'fonts'


def digest(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def matches(path, sha256, size=None):
    return path.is_file() and (size is None or path.stat().st_size == size) and digest(path) == sha256


def download(url, path, sha256, size=None):
    if matches(path, sha256, size):
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    part = path.with_name(path.name + '.part')
    last_error = None
    for attempt in range(3):
        offset = part.stat().st_size if part.exists() else 0
        if size is not None and offset >= size:
            part.unlink()
            offset = 0
        headers = {'User-Agent': 'typst-GBT1.1-2020'}
        if offset:
            headers['Range'] = f'bytes={offset}-'
        try:
            print(f'fetching {path.name} (attempt {attempt+1})', flush=True)
            request = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(request, timeout=45) as response:
                append = response.status == 206 and offset > 0
                if append and not response.headers.get('Content-Range', '').startswith(f'bytes {offset}-'):
                    raise ValueError(f'Unexpected response range for {path.name}')
                with part.open('ab' if append else 'wb') as stream:
                    shutil.copyfileobj(response, stream)
            if not matches(part, sha256, size):
                part.unlink()
                raise ValueError(f'Size or SHA-256 mismatch: {path.name}')
            part.replace(path)
            return
        except (OSError, ValueError) as error:
            last_error = error
            if attempt < 2:
                time.sleep(1)
    raise RuntimeError(f'Could not prepare {path.name}: {last_error}') from last_error


def prepare(check_only=False):
    manifest = json.loads((FONTS / 'manifest.json').read_text('utf8'))
    for item in manifest:
        name = item['file']
        if Path(name).name != name:
            raise ValueError(f'Unsafe font filename: {name}')
        path = FONTS / name
        if matches(path, item['sha256'], item['bytes']):
            print(f'verified {name}', flush=True)
            continue
        if check_only:
            raise SystemExit(f'Missing or corrupt font: {name}. Run python tools/bootstrap.py.')
        if 'archive_member' in item:
            archive = ROOT / '.tools/downloads' / Path(item['source']).name
            download(item['source'], archive, item['archive_sha256'])
            with tarfile.open(archive, 'r:gz') as bundle:
                member = bundle.getmember(item['archive_member'])
                if not member.isfile() or member.size != item['bytes']:
                    raise ValueError(f'Invalid archive member: {name}')
                with bundle.extractfile(member) as stream:
                    data = stream.read()
            if hashlib.sha256(data).hexdigest() != item['sha256']:
                raise ValueError(f'SHA-256 mismatch: {name}')
            path.parent.mkdir(parents=True, exist_ok=True)
            part = path.with_name(name + '.part')
            part.write_bytes(data)
            part.replace(path)
        else:
            download(item['source'], path, item['sha256'], item['bytes'])
        if not matches(path, item['sha256'], item['bytes']):
            raise ValueError(f'Font verification failed: {name}')
        print(f'verified {name}', flush=True)
    print(f'All {len(manifest)} project fonts verified.', flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true', help='Verify fonts without downloading.')
    args = parser.parse_args()
    prepare(args.check)

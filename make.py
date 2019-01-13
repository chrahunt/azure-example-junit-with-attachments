import argparse
from pathlib import Path


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='replace text')
    parser.add_argument('--input')
    parser.add_argument('--attachment')
    parser.add_argument('--output')
    args = parser.parse_args()
    contents = Path(args.input).read_text(encoding='utf-8')
    attachment_path = Path(args.attachment).absolute()
    attachment = f'[[ATTACHMENT|{attachment_path}]]'
    result = contents.format(attachment=attachment)
    Path(args.output).write_text(result, encoding='utf-8')

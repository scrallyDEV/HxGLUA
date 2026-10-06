"""Small deterministic fixture tests; full cached API is checked by hxgmod update."""
import json
import shutil
import subprocess
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
import hxgmod as cli


class Generator(unittest.TestCase):
    def test_alias_ownership_collision_idempotence_and_bad_input(self):
        with cli.staging_directory(cli.SDK_ROOT / '.work', 'generator-test-') as root:
            shutil.copytree(cli.SDK_ROOT / 'generator', root / 'generator')
            shutil.copy2(cli.SDK_ROOT / 'generator.hxml', root / 'generator.hxml')
            raw = root / 'api/raw'
            raw.mkdir(parents=True)
            entries = [{'type':'class', 'name':'Player'}, {'type':'class', 'name':'Entity'},
                       {'type':'struct', 'name':'Player'}, {'type':'enum', 'name':'PLAYER'},
                       {'type':'struct', 'name':'ENT'}, {'type':'struct', 'name':'SWEP'}]
            (raw / 'fixture.json').write_text(json.dumps(entries))
            public = root / 'src/gmod'
            public.mkdir(parents=True)
            handwritten = 'package gmod;\n// Docs mention @hxgmod-generated-public-alias but do not confer ownership.\nextern class Custom {}\n'
            (public / 'Custom.hx').write_text(handwritten)
            for name in ('ENT', 'SWEP'):
                shutil.copy2(cli.SDK_ROOT / f'src/gmod/{name}.hx', public / f'{name}.hx')
            (public / 'Stale.hx').write_text('// @hxgmod-generated-public-alias\npackage gmod; typedef Stale = Dynamic;')
            def generate(okay=True):
                result = subprocess.run(['haxe', 'generator.hxml'], cwd=root, capture_output=True, text=True)
                self.assertEqual(result.returncode == 0, okay, result.stdout + result.stderr)
            generate()
            self.assertFalse((public / 'Stale.hx').exists())
            self.assertEqual((public / 'Custom.hx').read_text(), handwritten)
            for name, target in [('Player','gmod.generated.Player'), ('PlayerEnum','gmod.generated.enums.PLAYER'),
                                 ('PlayerStruct','gmod.generated.structs.Player'), ('ENTStruct','gmod.generated.structs.ENT')]:
                self.assertIn(target, (public / f'{name}.hx').read_text())
            snapshot = {str(p.relative_to(public)): p.read_bytes() for p in public.rglob('*.hx')}
            generate()
            self.assertEqual(snapshot, {str(p.relative_to(public)): p.read_bytes() for p in public.rglob('*.hx')})
            (raw / 'broken.json').write_text('{broken')
            generate(okay=False)
            self.assertEqual(snapshot, {str(p.relative_to(public)): p.read_bytes() for p in public.rglob('*.hx')})


if __name__ == '__main__':
    unittest.main()

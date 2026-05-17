import json
import os
import re

script_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(script_dir)
xcstrings_path = os.path.join(project_root, 'Resources', 'Localizable.xcstrings')

with open(xcstrings_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

strings = data.get('strings', {})

locales = {'en': {}, 'de': {}, 'es': {}, 'ja': {}, 'ru': {}, 'pt': {}}

for key, value in strings.items():
    # Generate a valid Dart identifier for the key
    safe_key = re.sub(r'[^a-zA-Z0-9_]', '_', key)
    safe_key = re.sub(r'_+', '_', safe_key).strip('_')
    # camelCase
    parts = safe_key.split('_')
    if len(parts) > 0:
        safe_key = parts[0].lower() + ''.join(p.capitalize() for p in parts[1:])
    else:
        safe_key = 'empty_key'
    
    if safe_key[0].isdigit():
        safe_key = 's_' + safe_key

    # For 'en' source
    en_val = key
    en_val = en_val.replace('%lld', '{count}')
    en_val = en_val.replace('%@', '{item}')
    locales['en'][safe_key] = en_val
    
    if '{count}' in en_val or '{item}' in en_val:
        placeholders = {}
        if '{count}' in en_val:
            placeholders['count'] = {'type': 'int'}
        if '{item}' in en_val:
            placeholders['item'] = {'type': 'String'}
        locales['en']['@' + safe_key] = {'placeholders': placeholders}
    
    localizations = value.get('localizations', {})
    for loc, loc_data in localizations.items():
        if loc in locales:
            trans_val = loc_data.get('stringUnit', {}).get('value', '')
            trans_val = trans_val.replace('%lld', '{count}')
            trans_val = trans_val.replace('%@', '{item}')
            locales[loc][safe_key] = trans_val

# Merge and write arb files
l10n_dir = os.path.join(project_root, 'wpspsync_flutter', 'lib', 'l10n')
os.makedirs(l10n_dir, exist_ok=True)
for loc, trans in locales.items():
    if not trans and loc != 'en':
        continue
        
    arb_path = os.path.join(l10n_dir, f'app_{loc}.arb')
    existing_trans = {}
    
    # Load existing translations to preserve Flutter-specific strings
    if os.path.exists(arb_path):
        try:
            with open(arb_path, 'r', encoding='utf-8') as f:
                existing_trans = json.load(f)
        except Exception as e:
            print(f"Warning: Could not read existing {arb_path}: {e}")
            
    # Update existing translations with ones from Swift (Swift takes precedence for shared strings)
    existing_trans.update(trans)
    
    with open(arb_path, 'w', encoding='utf-8') as f:
        json.dump(existing_trans, f, ensure_ascii=False, indent=2)

print("ARB files generated.")

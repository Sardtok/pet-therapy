python3 -m unittest discover yage/tests -p "*_tests.py"
python3 -m unittest discover yage_live/tests -p "*_tests.py"
python3 -m unittest discover onscreen/tests -p "*_tests.py"
python3 -m unittest discover config/tests -p "*_tests.py"

echo "Signing as $EXPANDED_CODE_SIGN_IDENTITY_NAME ($EXPANDED_CODE_SIGN_IDENTITY)"
find "$CODESIGNING_FOLDER_PATH/Contents/Resources/python-stdlib/lib-dynload" -name "*.so" -exec /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" -o
runtime --timestamp=none --preserve-metadata=identifier,entitlements,flags --generate-entitlement-der {} \;

echo "Signing as Apple Development: Federico Curzel (R4A7YGNWNX) (C8A4C7D761E615E9CD02F70E0606D1DEE7B99E47)"
find "$CODESIGNING_FOLDER_PATH/Contents/Resources/python-stdlib/lib-dynload" -name "*.so" -exec /usr/bin/codesign --force --sign
"C8A4C7D761E615E9CD02F70E0606D1DEE7B99E47" -o runtime --timestamp=none --preserve-metadata=identifier,entitlements,flags --generate-entitlement-der {} \;

https://dev.to/eldare/embedding-python-interpreter-inside-a-macos-app-and-publish-to-the-app-store-successfully-4bop
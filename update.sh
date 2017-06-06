echo "Updating Tron..."
crown-cli stop
RELEASE=$(curl -s 'https://api.github.com/repos/Crowndev/crowncoin/releases/latest' | jq -r '.assets | .[] | select(.name=="crown-x86_64-unknown-linux-gnu.tar.gz") | .browser_download_url')
curl -sSL $RELEASE -o crown.tgz
tar xzf crown.tgz --no-anchored crownd crown-cli --transform='s/.*\///'
# use strip if installed
if hash strip 2>/dev/null; then
    strip crownd crown-cli
fi
sudo mv crownd crown-cli /usr/local/bin/
rm -rf crown*
crownd
echo "Update finished"

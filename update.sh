crown-cli stop
RELEASE=$(curl -s 'https://api.github.com/repos/Crowndev/crowncoin/releases/latest' | jq -r '.assets | .[] | select(.name=="crown-x86_64-unknown-linux-gnu.tar.gz") | .browser_download_url')
curl -sSL $RELEASE -o crown.tgz
tar xzf crown.tgz --no-anchored crownd crown-cli --transform='s/.*\///'
#strip crownd crown-cli
sudo mv crownd crown-cli /usr/local/bin/
rm -rf crown*
crownd
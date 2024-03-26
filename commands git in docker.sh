docker run -it --rm -v ${PWD}:/app ubuntu bash
apt update
apt install -y git
cd /app
git clone https://...
...
git add . && git commit -am "missatge" && git push
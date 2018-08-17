# Run Tests

1.) Update and clear repo
git pull
rm -rf build

2.) Nuke & reinstall
npm install

3.) Rebuild & test
truffle compile
truffle test
truffle migrate --network=kovan or truffle migrate --network=rinkeby

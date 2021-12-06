#!/usr/bin/env node

const childProcess = require('child_process');
const fs = require('fs');

process.chdir(__dirname);

const platform = process.platform == 'darwin' ? 'mac' : 'linux';

function requestUrl(url) {
    return childProcess.execFileSync('curl', ['--silent', '-L', url], { encoding: 'utf8' });
}

function fail(message) {
    console.error(message);
    process.exit(1);
}

function resolveLatestRelease() {

    var releases = JSON.parse(requestUrl('https://api.github.com/repos/ceramic-engine/ceramic/releases'));

    for (release of releases) {

        if (release.assets != null) {
            var assets = release.assets;
            for (asset of assets) {
                if (asset.name == 'ceramic-'+platform+'.zip') {
                    return release;
                }
            }
        }
    }

    fail('Failed to resolve latest ceramic version! Try again later?');
    return null;

}

function cleanup() {
    if (fs.existsSync('ceramic.zip'))
        childProcess.execFileSync('rm', ['ceramic.zip']);
    if (fs.existsSync('ceramic'))
        childProcess.execFileSync('rm', ['-rf', 'ceramic']);
}

function downloadFile(url, path) {
    childProcess.execFileSync('curl', ['-L', '-o', path, url]);
}

function unzipFile(source, targetPath) {
    childProcess.execFileSync('unzip', ['-q', source, '-d', targetPath]);
}

cleanup();

console.log('Resolve latest Ceramic release');
var releaseInfo = resolveLatestRelease();
var targetTag = releaseInfo.tag_name;
var ceramicZipPath = 'ceramic.zip';
var ceramicArchiveUrl = 'https://github.com/ceramic-engine/ceramic/releases/download/'+targetTag+'/ceramic-'+platform+'.zip';

console.log('Download ceramic archive: ' + ceramicArchiveUrl);
downloadFile(ceramicArchiveUrl, ceramicZipPath);

console.log('Unzip...');
unzipFile(ceramicZipPath, 'ceramic');

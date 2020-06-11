<?php


unset($argv[0]);
$argv = array_values($argv);

list(
    $projectPath,
    $clinikalJson
    ) = $argv;

if (is_file($clinikalJson)) {
    $clinikalArray = json_decode(file_get_contents($clinikalJson), true);
} else {
    echo "clinikal's composer.json not found";
    exit(1);
}

$openemrJson  = $projectPath .'/composer.json';

if (is_file($openemrJson)) {
    $openemrArray = json_decode(file_get_contents($openemrJson), true);
} else {
    echo "openemr's composer.json not found";
    exit(1);
}

$mergedJson = $openemrArray;
$mergedJson['name'] = $clinikalArray['name'];
$mergedJson['description'] = $clinikalArray['description'];
if (isset($clinikalArray['type'])) {
    $mergedJson['type'] = $clinikalArray['type'];
}
$mergedJson['authors'] = $clinikalArray['authors'];
unset($mergedJson['license']);
$mergedJson['repositories'] = array_merge($openemrArray['repositories'], $clinikalArray['repositories']);
foreach ($clinikalArray['require'] as $name => $value) {
    $mergedJson['require'][$name] = $value;
}
foreach ($clinikalArray['config'] as $name => $value) {
    $mergedJson['config'][$name] = $value;
}
if (isset($mergedJson['extra'])) {
    foreach ($clinikalArray['extra'] as $name => $value) {
        $mergedJson['extra'][$name] = $value;
    }
} else {
    $mergedJson['extra'] = $clinikalArray['extra'];
}
if (empty($mergedJson['require-dev'])) {
    unset($mergedJson['require-dev']);
}

file_put_contents($projectPath . '/composer-clinikal.json', json_encode($mergedJson, 192));

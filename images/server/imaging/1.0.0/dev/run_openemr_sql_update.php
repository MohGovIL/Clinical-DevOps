<?php

require_once ("openemr/version.php");
$current_version = "$v_major.$v_minor.$v_patch";

$_POST['form_submit'] = true;
$_POST['form_old_version'] = $current_version;
$_SERVER['HTTP_HOST'] = "default";
require_once ("openemr/sql_upgrade.php");

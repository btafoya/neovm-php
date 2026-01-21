<?php
/**
 * phpMyAdmin configuration for NixVM
 */

declare(strict_types=1);

/**
 * Server configuration
 */
$i = 1;
$cfg['Servers'][$i]['auth_type'] = 'config';
$cfg['Servers'][$i]['host'] = getenv('PMA_HOST') ?: 'db';
$cfg['Servers'][$i]['port'] = getenv('PMA_PORT') ?: 3306;
$cfg['Servers'][$i]['user'] = getenv('PMA_USER') ?: 'nixvm_user';
$cfg['Servers'][$i]['password'] = getenv('PMA_PASSWORD') ?: 'nixvm_pass';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = false;

/**
 * phpMyAdmin configuration
 */
$cfg['blowfish_secret'] = 'nixvm_phpmyadmin_secret_key_2024';

/**
 * UI preferences
 */
$cfg['DefaultLang'] = 'en';
$cfg['ServerDefault'] = 1;
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';

/**
 * Development settings
 */
$cfg['ShowAll'] = true;
$cfg['MaxRows'] = 100;
$cfg['Confirm'] = true;
$cfg['UseDbSearch'] = true;

/**
 * Security settings
 */
$cfg['AllowArbitraryServer'] = false;
$cfg['LoginCookieRecall'] = false;
$cfg['AllowUserDropDatabase'] = false;

/**
 * Theme configuration
 */
$cfg['ThemeDefault'] = 'pmahomme';
$cfg['ThemeManager'] = true;

/**
 * Other settings
 */
$cfg['ExecTimeLimit'] = 300;
$cfg['MemoryLimit'] = '256M';
$cfg['NavigationTreeEnableGrouping'] = true;
$cfg['NavigationTreeDbSeparator'] = '_';
$cfg['FirstLevelNavigationItems'] = 100;
$cfg['MaxNavigationItems'] = 250;
<!DOCTYPE html>
<?php

declare(strict_types=1);

// Environment detection
$appEnv = getenv('APP_ENV') ?: 'development';
$isProduction = $appEnv === 'production';
$isDevelopment = !$isProduction;

// Security: Hide errors in production
if ($isProduction) {
    ini_set('display_errors', '0');
    ini_set('display_startup_errors', '0');
    error_reporting(0);
} else {
    ini_set('display_errors', '1');
    ini_set('display_startup_errors', '1');
    error_reporting(E_ALL);
}

?>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NixVM PHP 8.3 <?php echo $isProduction ? 'Production' : 'Development'; ?> Environment</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .status {
            padding: 10px;
            margin: 10px 0;
            border-radius: 5px;
        }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        .code {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            font-family: 'Monaco', 'Menlo', monospace;
            border: 1px solid #dee2e6;
            overflow-x: auto;
        }
        h1 { color: #2c3e50; }
        h2 { color: #34495e; border-bottom: 2px solid #3498db; padding-bottom: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 NixVM PHP 8.3 <?php echo $isProduction ? 'Production' : 'Development'; ?> Environment</h1>

        <div class="status <?php echo $isProduction ? 'info' : 'success'; ?>">
            <strong>✅ Environment Status:</strong> PHP 8.3, MariaDB, and Caddy are configured and ready!
            <?php if ($isProduction): ?>
                <br><strong>🔒 Production Mode:</strong> Debug features disabled, errors hidden.
            <?php else: ?>
                <br><strong>🔧 Development Mode:</strong> Debug features enabled, full error reporting.
            <?php endif; ?>
        </div>

        <h2>📋 System Information</h2>
        <div class="code">
            <?php
            echo "Environment: " . ($isProduction ? "Production" : "Development") . "<br>";
            echo "PHP Version: " . phpversion() . "<br>";
            echo "Server Software: " . $_SERVER['SERVER_SOFTWARE'] . "<br>";
            if (!$isProduction) {
                echo "Document Root: " . $_SERVER['DOCUMENT_ROOT'] . "<br>";
            }
            echo "Current Time: " . date('Y-m-d H:i:s T') . "<br>";
            if ($isDevelopment) {
                echo "Error Reporting: " . (error_reporting() ? "Enabled" : "Disabled") . "<br>";
                echo "Display Errors: " . ini_get('display_errors') . "<br>";
            }
            ?>
        </div>

        <h2>🐘 PHP Extensions</h2>
        <div class="code">
            <?php
            $extensions = get_loaded_extensions();
            sort($extensions);

            // Highlight key extensions
            $keyExtensions = ['pdo_mysql', 'mysqli', 'gd', 'zip', 'imap', 'imagick', 'mbstring', 'curl'];

            foreach ($extensions as $ext) {
                $highlight = in_array($ext, $keyExtensions) ? ' style="color: #28a745; font-weight: bold;"' : '';
                echo '<span' . $highlight . '>' . $ext . '</span><br>';
            }
            ?>
        </div>
        <p><small><em style="color: #28a745;">Green extensions are key development extensions</em></small></p>

        <h2>🐬 Database Connection Test</h2>
        <?php
        try {
            $pdo = new PDO(
                'mysql:host=db;dbname=nixvm_sample;charset=utf8mb4',
                'nixvm_user',
                'nixvm_pass',
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                ]
            );

            // Test query
            $stmt = $pdo->query("SELECT COUNT(*) as user_count FROM users");
            $result = $stmt->fetch();

            echo '<div class="status success">';
            echo '<strong>✅ Database Connected!</strong><br>';
            if ($isDevelopment) {
                echo 'Users in database: ' . $result['user_count'];

                // Show recent posts only in development
                echo '<h3>📝 Recent Posts</h3>';
                echo '<div class="code">';
                $posts = $pdo->query("SELECT title, created_at FROM posts WHERE published = 1 ORDER BY created_at DESC LIMIT 5");
                foreach ($posts as $post) {
                    echo htmlspecialchars($post['title']) . ' (' . $post['created_at'] . ')<br>';
                }
                echo '</div>';
            } else {
                echo 'Database connection verified (details hidden in production)';
            }
            echo '</div>';

        } catch (PDOException $e) {
            echo '<div class="status" style="background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;">';
            echo '<strong>❌ Database Connection Failed:</strong><br>';
            if ($isDevelopment) {
                echo htmlspecialchars($e->getMessage());
            } else {
                echo 'Connection error (details hidden in production for security)';
            }
            echo '</div>';
        }
        ?>

        <?php if ($isDevelopment): ?>
        <h2>🛠️ Development Tools</h2>
        <div class="info">
            <strong>Available URLs:</strong><br>
            • Main site: <a href="http://localhost">http://localhost</a><br>
            • Alternative: <a href="http://dev.nixvm.localhost">http://dev.nixvm.localhost</a><br>
            • phpMyAdmin: <a href="http://localhost:8081">http://localhost:8081</a><br>
            <br>
            <strong>Database credentials:</strong><br>
            Host: db (or localhost:3306)<br>
            Database: nixvm_dev / nixvm_sample<br>
            User: nixvm_user<br>
            Password: nixvm_pass<br>
            Root Password: rootpassword
        </div>
        <?php endif; ?>

        <?php if ($isProduction): ?>
        <h2>📊 Production Status</h2>
        <div class="info">
            <strong>🚀 Application is running in production mode</strong><br>
            • Debug information is hidden<br>
            • Error reporting is disabled<br>
            • Security features are enabled<br>
            <br>
            <em>For administrative access, use proper production management tools.</em>
        </div>
        <?php endif; ?>

        <h2>📚 Getting Started</h2>
        <div class="code">
# Start the development environment
docker-compose up -d

# Or use Nix
nix develop

# Install PHP dependencies
composer install

# Access your application
# http://localhost
        </div>
    </div>
</body>
</html>
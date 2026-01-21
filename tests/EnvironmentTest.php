<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;

class EnvironmentTest extends TestCase
{
    public function test_php_version(): void
    {
        $this->assertEquals('8.3', explode('.', PHP_VERSION)[0] . '.' . explode('.', PHP_VERSION)[1]);
    }

    public function test_required_extensions(): void
    {
        $required = ['pdo_mysql', 'mysqli', 'mbstring', 'curl', 'gd', 'zip', 'imap', 'imagick'];

        foreach ($required as $extension) {
            $this->assertTrue(
                extension_loaded($extension),
                "Extension '{$extension}' is not loaded"
            );
        }
    }

    public function test_database_connection(): void
    {
        try {
            $pdo = new PDO(
                'mysql:host=db;dbname=nixvm_sample;charset=utf8mb4',
                'nixvm_user',
                'nixvm_pass',
                [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
            );

            $stmt = $pdo->query('SELECT 1 as test');
            $result = $stmt->fetch();

            $this->assertEquals(1, $result['test']);
        } catch (PDOException $e) {
            $this->fail('Database connection failed: ' . $e->getMessage());
        }
    }
}
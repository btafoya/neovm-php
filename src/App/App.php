<?php

declare(strict_types=1);

namespace NixVM\App;

class App
{
    private static ?self $instance = null;
    private string $environment;
    private bool $isProduction;

    private function __construct()
    {
        $this->environment = getenv('APP_ENV') ?: 'development';
        $this->isProduction = $this->environment === 'production';
    }

    public static function getInstance(): self
    {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getEnvironment(): string
    {
        return $this->environment;
    }

    public function isProduction(): bool
    {
        return $this->isProduction;
    }

    public function isDevelopment(): bool
    {
        return !$this->isProduction;
    }

    public function getVersion(): string
    {
        return '1.0.0';
    }

    public function getPhpVersion(): string
    {
        return PHP_VERSION;
    }
}

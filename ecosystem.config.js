module.exports = {
  apps: [
    {
      name: "state-of-law",
      script: "npm",
      args: "start",
      cwd: "/var/www/state-of-law",
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: "1G",
      env: {
        NODE_ENV: "development",
        PORT: 1337,
        HOST: "0.0.0.0",
      },
      env_production: {
        NODE_ENV: "production",
        PORT: 1337,
        HOST: "0.0.0.0",
      },
      error_file: "/var/log/pm2/state-of-law-error.log",
      out_file: "/var/log/pm2/state-of-law-out.log",
      log_file: "/var/log/pm2/state-of-law-combined.log",
      time: true,
    },
  ],
};

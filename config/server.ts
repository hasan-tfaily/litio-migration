module.exports = ({ env }) => ({
  host: env("HOST", "0.0.0.0"),
  port: env.int("PORT", 1337),
  url: env("PUBLIC_URL", "http://localhost:1337"),
  proxy: false, // set to true only when you put Nginx in front
  app: { keys: env.array("APP_KEYS") },
});

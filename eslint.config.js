// eslint.config.js (CommonJS 버전)
const { FlatCompat } = require("@eslint/eslintrc");

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommended: true,
});

module.exports = [
  ...compat.config({
    rules: {
      "no-unused-vars": "warn",
      semi: ["error", "always"],
      eqeqeq: "error",
      curly: "error",
      "no-console": "warn",
      indent: ["error", 2],
    },
  }),
];

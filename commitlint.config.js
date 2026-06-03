module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    // 허용 타입만
    "type-enum": [2, "always", ["feat", "fix", "refactor", "chore", "docs"]],

    // subject 필수
    "subject-empty": [2, "never"],

    // scope는 commitlint에서 강제하지 않고 훅에서 처리
    "scope-empty": [0, "always"],
  },
};

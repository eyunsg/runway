module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',

  testMatch: ['<rootDir>/test/**/*.test.ts'],

  transform: {
    '^.+\\.ts$': 'ts-jest',
  },

  moduleNameMapper: {
    '^(\\.{1,2}/.*)\\.ts$': '$1',
  },
};

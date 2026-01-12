/**
 * Commitlint configuration for homelab infrastructure repository.
 * Follows Conventional Commits + Angular-style guidelines.
 *
 * @see https://commitlint.js.org/
 * @see docs/commit_convention.md
 */
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // Header: max 100 chars (Angular guideline)
    'header-max-length': [2, 'always', 100],

    // Type: must be one of the allowed types
    'type-enum': [
      2,
      'always',
      [
        'feat',     // new capability / behavior
        'fix',      // bug/defect regression
        'docs',     // documentation only
        'style',    // formatting, whitespace
        'refactor', // restructure, no behavior change
        'perf',     // performance improvement
        'test',     // add/fix tests only
        'build',    // build system/deps packaging
        'ci',       // pipeline config changes
        'chore',    // maintenance, deps, tooling
        'revert',   // revert a previous commit
      ],
    ],

    // Scope: optional but recommended; must be lowercase
    'scope-case': [2, 'always', 'lower-case'],
    'scope-enum': [
      1, // warning only - allow unlisted scopes for flexibility
      'always',
      [
        // Infrastructure
        'k8s',
        'helm',
        'terraform',
        'ansible',
        'argocd',
        'kustomize',

        // Networking & Security
        'network',
        'security',
        'firewall',
        'vpn',

        // Observability
        'monitoring',
        'alerting',
        'observability',

        // Platform
        'ci',
        'build',
        'deps',
        'storage',

        // Documentation & Policies
        'docs',
        'adr',
        'runbook',
        'policies',

        // Scripts & Tests
        'scripts',
        'tests',
      ],
    ],

    // Subject: imperative, present tense, no trailing period
    'subject-case': [2, 'always', 'lower-case'],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],

    // Body: blank line after header
    'body-leading-blank': [2, 'always'],
    'body-max-line-length': [2, 'always', 100],

    // Footer: blank line before footer
    'footer-leading-blank': [2, 'always'],
    'footer-max-line-length': [2, 'always', 100],
  },
};

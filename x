#!/usr/bin/env node
import assert from 'node:assert/strict'
import {controlPictures} from 'control-pictures'
import {remark} from 'remark'
import remarkGfm from 'remark-gfm'
import remarkLintTablePipeAlignment from 'remark-lint-table-pipe-alignment'
import {removePosition} from 'unist-util-remove-position'
import {VFile} from 'vfile'
import {plugins} from './script/info.js'

const [plugin] = plugins.filter(p => p.name === 'remark-lint-table-pipe-alignment')
const [check] = plugin.checks.filter(c => c.name === 'ok.md')

const value = controlPictures(check.input)

const file = await remark()
  .use(remarkLintTablePipeAlignment, true)
  .use([remarkGfm])
  .process(new VFile({path: check.name, value}))

for (const message of file.messages) {
  assert.equal(message.ruleId, plugin.ruleId)
  assert.equal(
    message.url,
    'https://github.com/remarkjs/remark-lint/tree/main/packages/remark-lint-' +
      plugin.ruleId +
      '#readme'
  )
}

assert.deepEqual(
  file.messages.map(String).map(function (value) {
    return value.slice(value.indexOf(':') + 1)
  }),
  check.output
)

if (!check.positionless) {
  const file = await remark()
    .use(function () {
      return function (tree) {
        removePosition(tree)
      }
    })
    .use(remarkLintTablePipeAlignment, true)
    .use([remarkGfm])
    .process(new VFile({path: check.name, value}))

  assert.deepEqual(file.messages, [])
}

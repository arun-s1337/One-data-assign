const express = require('express')
const app = express()
const port = 3000
const pgp = require('pg-promise')(/* options */)
const db = pgp(process.env.POSTGRESQL_URL || 'postgres://username:password@host:port/database')

app.get('/', async (req, res) => {
  const result = await db.one('SELECT $1 AS value', 123)
  res.send(`Hello World from service 2. DB result is ${JSON.stringify(result)}`)
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
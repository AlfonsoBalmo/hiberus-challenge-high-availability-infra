const express = require('express');
const db = require('./database');

const app = express();

app.get('/', async (req, res) => {
    try {
        const result = await db.query('SELECT * FROM mytable');
        res.json(result);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = app;

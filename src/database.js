const mysql = require('mysql2/promise');
const config = require('./config');

const pool = mysql.createPool(config.db);

module.exports = {
    query: async (query, params) => {
        const [results] = await pool.query(query, params);
        return results;
    },
};

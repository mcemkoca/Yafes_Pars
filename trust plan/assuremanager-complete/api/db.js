const sql = require('mssql');

const config = {
  server: process.env.DB_SERVER || 'localhost',
  database: process.env.DB_NAME || 'AssureManagerDB',
  user: process.env.DB_USER || 'sa',
  password: process.env.DB_PASSWORD || '',
  options: {
    encrypt: false,
    trustServerCertificate: true,
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
};

const pool = new sql.ConnectionPool(config);
let poolConnected = false;

// Check DB availability
async function checkConnection() {
  try {
    if (!poolConnected) {
      await pool.connect();
      poolConnected = true;
      console.log('SQL Server connected successfully');
    }
    return true;
  } catch (err) {
    if (poolConnected) {
      poolConnected = false;
    }
    console.warn('SQL Server not available, using mock data');
    return false;
  }
}

module.exports = { sql, pool, checkConnection };

const handler = require('../dist/vercel-handler').default;

module.exports = async (req, res) => {
  return handler(req, res);
};

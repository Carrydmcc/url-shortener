const query = require("./queries");
const utils = require("./utils");

setInterval(function () {
  query.link.batchRemove({ expire_in: ["<", utils.dateToUTC(new Date())] }).catch();
}, 30_000);

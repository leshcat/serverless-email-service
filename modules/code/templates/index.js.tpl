
var LambdaForwarder = require("aws-lambda-ses-forwarder");

exports.handler = function(event, context, callback) {
  // See aws-lambda-ses-forwarder/index.js for all options.
  var overrides = {
    config: ${lambda_config}
  };
  LambdaForwarder.handler(event, context, callback, overrides);
};

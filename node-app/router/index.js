/**
 * every file represete collection of routes
 * this may be loosely considered as controller
 */
module.exports = function (app) {
    app.use('/', require('./routes/home'));
    app.use('/user', require('./routes/user'));
    app.use('/test/well', require('./routes/Test/index'));
};
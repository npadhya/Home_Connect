var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {

	var users = [
        { name: 'Bloody Mary', drunkness: 'Good' },
        { name: 'Martini', drunkness: 'Better' },
        { name: 'Scotch', drunkness: 'Best' }
    ];
    var tagline = "Hope For The Best, Prepare For The Worst";

    res.render('pages/user/list', {
        users: users,
        tagline: tagline
    });

});

// POST /user
router.post('/', function (req, res) {
    // handle a post request to this route
    res.send('POST: respond with a user resource');
});

// GET /user/info
router.get('/info', function (req, res) {
	res.send('respond with a user info resource');
    // handle a get request to this route
});


module.exports = router;

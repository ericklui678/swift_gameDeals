var express = require('express'),
  bodyParser = require('body-parser'),
  mongoose = require('mongoose'),
  // port = 8000,
  app = express();
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json())
app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

app.set('port', (process.env.PORT || 8000))

var uristring =
process.env.MONGOLAB_URI ||
process.env.MONGOHQ_URL ||
'mongodb://heroku_t05dnrwd:la2ijp9nttr5t62skgipbcoh89@ds151163.mlab.com:51163/heroku_t05dnrwd'

mongoose.connect(uristring, function (err, res) {
  if (err) {
    console.log('failed to connect to db');
  } else {
    console.log('Successfully db connection');
  }
})

var Schema = mongoose.Schema;

var GameDealsSchema = new mongoose.Schema({
  game_id: { type: String, required: [true, 'game id required'] },
  imgURL: { type: String, required: [true, 'image url required'] },
  title: { type: String, required: [true, 'title required'] },
}, { timestamps: true });
var GameDeals = mongoose.model('gamedeals', GameDealsSchema)

// Show form, delete this later
app.get('/new', function(req, res){
  res.render('new')
})
// Show your list
app.get('/', function(req, res){
  GameDeals.find(function(err, data){
    if(err) {console.log(err);}
    res.send(data);
  }).sort({'createdAt': -1})
})
// Create
app.post('/create', function(req, res){
  GameDeals.create(req.body, function(err, data){
    if(err) {console.log(err);}
    res.redirect('/');
  })
})
// Delete
app.post('/delete/:id', function(req, res){
  GameDeals.remove({game_id: req.params.id}, function(err, data){
    if(err) {console.log(err);}
    res.redirect('/')
  })
})

var server = app.listen(app.get('port'), function(){
  console.log("Node app is running on port", app.get('port'));
});

var express = require('express'),
  bodyParser = require('body-parser'),
  mongoose = require('mongoose'),
  port = 8000,
  app = express();
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json())
app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');
mongoose.connect('mongodb://localhost/gamedeals');

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
  })
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
app.listen(port, function(){
  console.log('running on', port);
})

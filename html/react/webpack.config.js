var webpack = require('webpack');
var path = require('path');

var BUILD_DIR = path.resolve(__dirname, 'build');
var APP_DIR = path.resolve(__dirname, 'src');

var config = {
  entry: APP_DIR + '/index.js',
  output: {
    path: BUILD_DIR,
    filename: 'bundle.js'
  },
  module : {
    loaders: [
      {
        test: /\.css$/,
        loader: 'style-loader'
      },
      {
        test: /\.css$/,
        loader: 'css-loader'/*,
        query: {
          modules: true,
          localIdentName: '[name]__[local]__[hash:base64:5]'
        }*/
      },
      {
        test : /\.jsx?/,
        include : APP_DIR,
        loader : 'babel-loader'
      },
      {
        test: /\.(htm|html)$/,
        loader: 'file-loader',
        options: {
          name: '[path][name].[ext]',
          context: 'src'
        }
      }
    ]
  }
};

module.exports = config;

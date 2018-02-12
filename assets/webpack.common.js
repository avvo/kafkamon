const { resolve } = require("path");
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");

module.exports = {
  entry: {
    app: ["./js/app.js", "./css/app.css"]
  },
  output: {
    path: resolve(__dirname, "../priv/static/"),
    filename: "js/[name].js"
  },
  resolve: {
    extensions: [".js", ".jsx"]
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract("css-loader")
      },
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader"
        }
      }
    ]
  },
  plugins: [
    new CopyWebpackPlugin([{ from: "./static" }]),
    new ExtractTextPlugin("css/app.css")
  ]
};

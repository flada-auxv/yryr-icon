require 'dotenv'
Dotenv.load

require 'sass/plugin/rack'
require_relative 'yryr_icon'

Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

run YRYRIcon

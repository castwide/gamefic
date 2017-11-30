import React from 'react';
import {render} from 'react-dom';
import {Console} from 'react-gamefic';
import {OpalDriver} from 'gamefic-driver';
import 'engine/opal.js';
var media = require.context('media');
import style from './style.css';

var driver = new OpalDriver(Opal);
render(<Console className="Console" driver={driver} />, document.getElementById('root'));

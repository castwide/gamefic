import React from 'react';
import {render} from 'react-dom';
import {Console} from 'react-gamefic';
import {OpalDriver} from 'gamefic-driver';
import './index.html';
import style from './style.css';

var driver = new OpalDriver();
render(<Console className="Console" driver={driver} />, document.getElementById('app'));

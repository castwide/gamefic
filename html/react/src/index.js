import React from 'react';
import {render} from 'react-dom';
import {Console} from './Console';
import './index.html';
import style from './style.css';

render(<Console className="Console" />, document.getElementById('app'));

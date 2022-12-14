import url from 'url';
import _ from 'lodash';
import type { Socket } from 'socket.io';
import type { IncomingHttpHeaders } from "http";
import type { SSH } from '../shared/interfaces';
import { address } from './command/address.js';
import { loginOptions } from './command/login.js';
import { sshOptions } from './command/ssh.js';

const localhost = (host: string): boolean =>
  process.getuid() === 0 &&
  (host === 'localhost' || host === '0.0.0.0' || host === '127.0.0.1');

function urlArgs(
  headers: IncomingHttpHeaders,
  def: { [s: string]: string },
): { [s: string]: string } {
  // https://stackoverflow.com/a/28420962/8608146
  console.log("****************************", headers, headers.authorization);
  let username : string|string[]|undefined;
  if (!_.isUndefined(headers.authorization)) {
    // TODO handle errors properly
    try {
      const parts = decodeURIComponent(escape(atob(headers.authorization.split(' ')[1]))).split(':');
      let pass = "";
      [username,  pass] = parts;
      console.log("****************************", pass, def);
      Object.assign(def, {pass});
      console.log("****************************", pass, def);
    }
    catch (e) {
      console.error(e);
    }
  }
  console.log("****************************", def);
  const refParams = url.parse(headers.referer || '', true).query;
  if (!username) {
    username = headers["remote-user"];
    if (!username)
      return Object.assign(def, refParams);
  } 
  if (!refParams.host) return Object.assign(def, refParams);
  Object.assign(def, {host:`${username}@${refParams.host}`});
  console.log("****************************", def);
  return def;
}

export function getCommand(
  {
    request: { headers },
    client: {
      conn: { remoteAddress },
    },
  }: Socket,
  {
    user,
    host,
    port,
    auth,
    pass,
    key,
    knownHosts,
    config,
    allowRemoteHosts,
  }: SSH,
  command: string,
  forcessh: boolean,
): [string[], boolean] {
  const sshAddress = address(headers, user, host);
  if (!forcessh && localhost(host)) {
    return [loginOptions(command, remoteAddress), true];
  }
  const args = urlArgs(headers, {
    host: sshAddress,
    port: `${port}`,
    pass: pass || '',
    command,
    auth,
    knownHosts,
    config: config || '',
  });
  if (!allowRemoteHosts) {
    args.host = sshAddress;
  }

  return [
    sshOptions(args, key),
    user !== '' || user.includes('@') || sshAddress.includes('@'),
  ];
}

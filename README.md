# Collectd unixsocket Ruby wrapper

Ruby class to access collectd daemon through the UNIX socket plugin.

Requires collectd to be configured with the unixsock plugin, like so:

    LoadPlugin unixsock

    <Plugin unixsock>
      SocketFile "/var/run/collectd-unixsock"
    </Plugin>

See http://collectd.org/wiki/index.php/Plugin:UnixSock

## Example

It's easy.

    hostname = Socket.gethostname

    Uxsock::CollectdUnixSock.open do |socket|
      socket.each_value do |time, id|
        puts "#{time}: #{id}"
      end

      socket.each_value_data("#{hostname}/load/load") do |col, val|
        puts "#{col}: #{val}\n"
      end

      socket.putnotif "Hello collectd!"

      socket.putval "#{hostname}/example/counter", 2
    end

When you run it you get something like:

    > LISTVAL
    < 22 Values found
    < 1449218943.504 myhostname.com/load/load
    2015-12-04 09:49:03 +0100: (myhostname.com) load/load
    < 1449218943.504 myhostname.com/memory/memory-used
    2015-12-04 09:49:03 +0100: (myhostname.com) memory/memory-used
    ...
    < 1449218943.505 myhostname.com/uptime/uptime
    2015-12-04 09:49:03 +0100: (myhostname.com) uptime/uptime

    > GETVAL "myhostname.com/load/load"
    < 3 Values found
    < shortterm=1.000000e-02
    shortterm: 1.000000e-02
    < midterm=5.000000e-02
    midterm: 5.000000e-02
    < longterm=5.000000e-02
    longterm: 5.000000e-02

    > PUTNOTIF time=1449218945 severity=okay message="Hello collectd!"
    < 0 Success

    > PUTVAL "myhostname.com/example/counter" N:2 
    < 0 Success: 1 value has been dispatched.

No rocket science.

## Copyright

Copyright (C) 2015 Red Hat
Author: Lukas Zapletal <lukas-x@zapletalovi.com>

Copyright (C) 2009 Novell Inc.
Author: Duncan Mac-Vicar P. <dmacvicar@suse.de>

Inspired in python version from collectd/contrib:
Copyright (C) 2008 Clay Loveless <clay@killersoft.com>

## License

Distributed under ZLib license.

This software is provided 'as-is', without any express or implied
warranty.  In no event will the author be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

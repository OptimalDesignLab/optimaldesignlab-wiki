I believe I've finally solved the ssh time-out issue that plagues us that work off campus. It's pretty simple: 

1. On the 'client' computer (your personal computer), insert the following line into `~/.ssh/config`:

>`ServerAliveInterval 120`

2. On the 'server' computer (the SCOREC machine), insert the following lines into `~/.ssh/sshd_config`:

>`ClientAliveInterval 120`
>`ClientAliveCountMax 720`

The effect is that null packets are sent every 120 seconds to keep the connection alive, a maximum of 720 times. This corresponds to 24 hours.

You might have to create either or both of those files if they're not present.

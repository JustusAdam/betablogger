For a month or so I've now had the 'justus.science' domain, on which, amongst other things, this homepage can be found. Sort of around the same time I moved host, from [uberspace](https://uberspace.de) to [GitHub Pages](https://pages.github.com), and infrastructure, from [Drupal](https://drupal.org) to the (much) more lightweight [Jekyll](http://jekyllrb.com).

By default GitHub pages domains look like this: username.github.io. In my case that would be justusadam.github.io, which is neither short nor particularly pretty. You can add custom domains to a GitHub page though, which I intended to make use of.

In order to add a custom domain to a GitHub page you have to configure the appropriate DNS entry with the provider. I, as per usual, read the manual fast and loosely and as a result thought the DNS entry **had** to be a CNAME, a belief which was reinforced by the fact that the file that has to be put into the repository and tells GitHub what the custom domain for the page is called, bears the name 'CNAME'.

So I registered a CNAME entry with united domains. The domain resolved as expected and the address bar in the browser was showing the right thing (the custom domain), everything seemed right with the world.

Then I tried to set up email with the new domain, as I had done with the other domain before by setting an MX entry pointing to the uberspace mailserver. It didn't work. I sent a few test mails, none of them arrived. The SMTP server tried three times and eventually gave up. Every mail was getting dropped. I changed the entry and redirected to gmail instead, that seemed to work[^gmail].

[^gmail]:
    Knowing what I know now it might be that I am not remembering the timeline correctly and it might be I had the email redirect **before** I set the CNAME entry for the site and changed it to an MX later, that would make more sense at least.

I could not figure out what was causing the issue. I decided it probably was the mailserver that for some reason could not deal with the new domain ending, a claim that, as I realize now, was pretty stupid. I decided to leave it for now, since in my mind the error did not appear to be on my side and I did not depend on the mail addresses.

That could have been the end of it, if not for a couple of days ago, when I decided it was time to pick the issue back up and get it sorted out. I sent an email to the excellent uberspace support and told them the server was not receiving mails to one of my domains and what I thought the reason was. They came back to me with a simple fact that made the problem obvious.

Turns out setting a CNAME entry for a domain pretty much overrides everything. CNAME's are designed to redirect *all* traffic to a (sub)domain to another domain, all traffic, including email. When A CNAME has been set the DNS server will ignore any other entry for that same name or flat out reject you setting any additional entries for the domain. Thus by setting one for 'justus.science' I inadvertently directed all emails going to *any-address@justus.science* to GitHub pages, which does not provide an email service and as a result dropped them.

Fixing it was rather simple. A second look at the GitHub pages help pages revealed that, any type of DNS entry could be used for a page (and why shouldn't it). So I changed the CNAME entrty to an A entry[^aentry] to [GitHub's IP][githubname], waited for the TTL to expire, send test mails again and suddenly they all arrived as expected, where expected. The MX entry was in effect.

[githubname]: https://help.github.com/articles/tips-for-configuring-an-a-record-with-your-dns-provider/

[^aentry]:
    If you'd like to know more about setting A names with GitHub, [here][githubname] is the official help page.

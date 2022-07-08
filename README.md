# The Chromium Searcher
A text file searching tool like The Silver Searcher, but in Ruby

# About this project
The following set of chronological events triggered and inspired the creation of this project:
1. In learning of and using the [dotfiles](https://github.com/mscoutermarsh/dotfiles) from @mscoutermarsh, I learned about [The Silver Searcher](https://github.com/ggreer/the_silver_searcher)
2. In learning of and using `ag` command line utility tool from @ggreer, I learned about how much faster it was than previous like tools by better using the multiple cores on our personal computers (by searching for the *text* input across multiple files in parallel)
3. The `ag` tool impressed me so much and was such a good example of how modern software needs to be developed to better use the multiple cores that modern day CPUs have, that I wrote a [blog post](https://rrevi.github.io/about-the-silver-searcher) about it!
4. I was intrigued enough about both The Silver Searcher and Ruby's new concurrency features in version 3.0+, that I decided to write the equilant of the former in in the latter.

This is all to say that this project is an **EDUCATIONAL** endeavor of my part, to mimic The Silver Searcher tool using the Ruby language new concurrency feaures (in version 3.0+).

# What's in a name?
In a Ruby gemstone, Chromium is the element that causes the gemstone to radiate the color red. The `cr` executable command is the element symbol for the Chromium element.

# Resources
Below is a brief list of resources I used to develop this project:
1. Book: [Text Processing with Ruby](https://pragprog.com/titles/rmtpruby/text-processing-with-ruby/)
2. Book: [Build Awesome Command-Line Applications in Ruby](https://naildrivin5.com/books/index.html)
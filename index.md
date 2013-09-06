---
layout: page
title: 文章列表
tagline:
---
{% include JB/setup %}

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
    <div>{{post.content}}</div>
    <div></div>
  {% endfor %}
</ul>

---
###About Me
我叫草丁，开发工程师，有梦，在想。



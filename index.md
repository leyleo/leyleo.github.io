---
layout: page
title: @草丁
tagline: 不爱吃糖
---
{% include JB/setup %}

<ul class="posts">
  {% for post in site.posts %}
    <div><h3><span>{{ post.date | date_to_string }} &raquo; </span><a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></h3></div>
    <div>{{post.content}}</div>
    <div></div>
  {% endfor %}
</ul>

---
####About Me
我叫草丁，开发工程师，有梦，在想。



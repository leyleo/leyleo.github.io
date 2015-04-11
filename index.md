---
layout: page
title: "@Home"
tagline: 
---
{% include JB/setup %}

<ul class="posts">
  {% for post in site.posts %}
    <div id="postTitle"><h3><span>{{ post.date | date_to_string }} &raquo; </span><a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></h3></div>
    <div>{{post.excerpt}}</div>
    <ul class="tag_box inline">
    	<li class="icon-tags"></li>
	    {% assign tags_list = post.tags %}
	    {% include JB/tags_list %}
	</ul>
  {% endfor %}
</ul>

---

####About Me

我叫草丁，开发工程师，有梦，在想。



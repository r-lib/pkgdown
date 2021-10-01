# tweak_tabsets() default

    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
    <html><body><div id="results-in-tabset" class="section level2 tabset">
    <h2 class="hasAnchor">
    <a href="#results-in-tabset" class="anchor" aria-hidden="true"></a>Results in tabset</h2>
    
    
    <ul class="nav nav-tabs nav-row" id="results-in-tabset" role="tablist">
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-1" role="tab" aria-controls="tab-1" aria-selected="false" class="active nav-link">Tab 1</a></li>
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-2" role="tab" aria-controls="tab-2" aria-selected="false" class="nav-link">Tab 2</a></li>
    </ul>
    <div class="tab-content">
    <div id="tab-1" class="active tab-pane" role="tabpanel"  aria-labelledby="tab-1">
    
    <p>blablablabla</p>
    <div class="sourceCode" id="cb9"><pre class="downlit sourceCode r">
    <code class="sourceCode R"><span class="fl">1</span> <span class="op">+</span> <span class="fl">1</span></code></pre></div>
    </div>
    <div id="tab-2" class="tab-pane" role="tabpanel"  aria-labelledby="tab-2">
    
    <p>blop</p>
    </div>
    </div>
    </div></body></html>

# tweak_tabsets() with tab pills and second tab active

    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
    <html><body><div id="results-in-tabset" class="section level2 tabset tabset-pills">
    <h2 class="hasAnchor">
    <a href="#results-in-tabset" class="anchor" aria-hidden="true"></a>Results in tabset</h2>
    
    
    <ul class="nav nav-pills nav-row" id="results-in-tabset" role="tablist">
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-1" role="tab" aria-controls="tab-1" aria-selected="false" class="nav-link">Tab 1</a></li>
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-2" role="tab" aria-controls="tab-2" aria-selected="true" class="nav-link active">Tab 2</a></li>
    </ul>
    <div class="tab-content">
    <div id="tab-1" class="tab-pane" role="tabpanel"  aria-labelledby="tab-1">
    
    <p>blablablabla</p>
    <div class="sourceCode" id="cb9"><pre class="downlit sourceCode r">
    <code class="sourceCode R"><span class="fl">1</span> <span class="op">+</span> <span class="fl">1</span></code></pre></div>
    </div>
    <div id="tab-2" class="active tab-pane" role="tabpanel"  aria-labelledby="tab-2">
    
    <p>blop</p>
    </div>
    </div>
    </div></body></html>

# tweak_tabsets() with tab pills, fade and second tab active

    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
    <html><body><div id="results-in-tabset" class="section level2 tabset tabset-pills tabset-fade">
    <h2 class="hasAnchor">
    <a href="#results-in-tabset" class="anchor" aria-hidden="true"></a>Results in tabset</h2>
    
    
    <ul class="nav nav-pills nav-row" id="results-in-tabset" role="tablist">
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-1" role="tab" aria-controls="tab-1" aria-selected="false" class="nav-link">Tab 1</a></li>
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-2" role="tab" aria-controls="tab-2" aria-selected="true" class="nav-link active">Tab 2</a></li>
    </ul>
    <div class="tab-content">
    <div id="tab-1" class="fade tab-pane" role="tabpanel"  aria-labelledby="tab-1">
    
    <p>blablablabla</p>
    <div class="sourceCode" id="cb9"><pre class="downlit sourceCode r">
    <code class="sourceCode R"><span class="fl">1</span> <span class="op">+</span> <span class="fl">1</span></code></pre></div>
    </div>
    <div id="tab-2" class="show active fade tab-pane" role="tabpanel"  aria-labelledby="tab-2">
    
    <p>blop</p>
    </div>
    </div>
    </div></body></html>


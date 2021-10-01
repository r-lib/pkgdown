# sections with class .tabset are converted to tabsets

    <div id="tabset" class="section level1 tabset tabset-pills">
    <h1 class="tabset tabset-pills">Tabset</h1>
    
    
    <ul class="nav nav-pills nav-row" id="tabset" role="tablist">
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-1" role="tab" aria-controls="tab-1" aria-selected="false" class="active nav-link">Tab 1</a></li>
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-2" role="tab" aria-controls="tab-2" aria-selected="false" class="nav-link">Tab 2</a></li>
    </ul>
    <div class="tab-content">
    <div id="tab-1" class="active tab-pane" role="tabpanel"  aria-labelledby="tab-1">
    
    <p>Contents 1</p>
    </div>
    <div id="tab-2" class="tab-pane" role="tabpanel"  aria-labelledby="tab-2">
    
    <p>Contents 2</p>
    </div>
    </div>
    </div>

# can adjust active tab

    <div id="tabset" class="section level2 tabset tabset-pills">
    <h2 class="tabset tabset-pills">Tabset</h2>
    
    
    <ul class="nav nav-pills nav-row" id="tabset" role="tablist">
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-1" role="tab" aria-controls="tab-1" aria-selected="false" class="nav-link">Tab 1</a></li>
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-2" role="tab" aria-controls="tab-2" aria-selected="true" class="nav-link active">Tab 2</a></li>
    </ul>
    <div class="tab-content">
    <div id="tab-1" class="tab-pane" role="tabpanel"  aria-labelledby="tab-1">
    
    <p>Contents 1</p>
    </div>
    <div id="tab-2" class="active tab-pane" role="tabpanel"  aria-labelledby="tab-2">
    
    <p>Contents 2</p>
    </div>
    </div>
    </div>

# can fades

    <div id="tabset" class="section level2 tabset tabset-fade">
    <h2 class="tabset tabset-fade">Tabset</h2>
    
    
    <ul class="nav nav-tabs nav-row" id="tabset" role="tablist">
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-1" role="tab" aria-controls="tab-1" aria-selected="false" class="nav-link">Tab 1</a></li>
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-2" role="tab" aria-controls="tab-2" aria-selected="true" class="nav-link active">Tab 2</a></li>
    </ul>
    <div class="tab-content">
    <div id="tab-1" class="fade tab-pane" role="tabpanel"  aria-labelledby="tab-1">
    
    <p>Contents 1</p>
    </div>
    <div id="tab-2" class="show active fade tab-pane" role="tabpanel"  aria-labelledby="tab-2">
    
    <p>Contents 2</p>
    </div>
    </div>
    </div>


# sections with class .tabset are converted to tabsets

    <div class="section level1 tabset tabset-pills">
    <h1 id="tabset">Tabset<a class="anchor" aria-label="anchor" href="#tabset"></a>
    </h1>
    
    
    <ul class="nav nav-pills" id="tabset" role="tablist">
    <li role="presentation" class="nav-item"><button data-bs-toggle="tab" data-bs-target="#tab-1" id="tab-1-tab" type="button" role="tab" aria-controls="tab-1" aria-selected="true" class="active nav-link">Tab 1</button></li>
    <li role="presentation" class="nav-item"><button data-bs-toggle="tab" data-bs-target="#tab-2" id="tab-2-tab" type="button" role="tab" aria-controls="tab-2" aria-selected="false" class="nav-link">Tab 2</button></li>
    </ul>
    <div class="tab-content">
    <div class="active  tab-pane" id="tab-1" role="tabpanel" aria-labelledby="tab-1-tab">
    
    <p>Contents 1</p>
    </div>
    <div class="tab-pane" id="tab-2" role="tabpanel" aria-labelledby="tab-2-tab">
    
    <p>Contents 2</p>
    </div>
    </div>
    </div>


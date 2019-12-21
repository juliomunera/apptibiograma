import { NgModule } from '@angular/core';
import { PreloadAllModules, RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  {
    path: '',
    redirectTo: 'home',
    pathMatch: 'full'
  },
  {
    path: 'home',
    loadChildren: () => import('./pages/home/home.module').then(m => m.HomePageModule)
  },
  { path: 'about', loadChildren: './pages/about/about.module#AboutPageModule' },
  { path: 'legal', loadChildren: './pages/legal/legal.module#LegalPageModule' },
  { path: 'general', loadChildren: './pages/general/general.module#GeneralPageModule' },
  { path: 'bacterium', loadChildren: './pages/bacterium/bacterium.module#BacteriumPageModule' },
  { path: 'gram', loadChildren: './pages/gram/gram.module#GramPageModule' },
  { path: 'infection', loadChildren: './pages/infection/infection.module#InfectionPageModule' },
  { path: 'input', loadChildren: './pages/input/input.module#InputPageModule' },
  { path: 'summary', loadChildren: './pages/summary/summary.module#SummaryPageModule' },
  { path: 'test', loadChildren: './pages/test/test.module#TestPageModule' }
];

@NgModule({
  imports: [
    RouterModule.forRoot(routes, { preloadingStrategy: PreloadAllModules })
  ],
  exports: [RouterModule]
})
export class AppRoutingModule {}

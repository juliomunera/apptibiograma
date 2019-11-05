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
    loadChildren: () => import('./home/home.module').then(m => m.HomePageModule)
  },
  { path: 'about', loadChildren: './about/about.module#AboutPageModule' },
  { path: 'legal', loadChildren: './legal/legal.module#LegalPageModule' },
  // { path: 'code', loadChildren: './code/code.module#CodePageModule' },
  { path: 'general', loadChildren: './general/general.module#GeneralPageModule' },
  // { path: 'body', loadChildren: './body/body.module#BodyPageModule' },
  { path: 'bacterium', loadChildren: './bacterium/bacterium.module#BacteriumPageModule' },
  { path: 'gram', loadChildren: './gram/gram.module#GramPageModule' },
  { path: 'infection', loadChildren: './infection/infection.module#InfectionPageModule' }
];

@NgModule({
  imports: [
    RouterModule.forRoot(routes, { preloadingStrategy: PreloadAllModules })
  ],
  exports: [RouterModule]
})
export class AppRoutingModule {}

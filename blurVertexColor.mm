#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import <vector>

#define SECOND_PASS

int main(int argc, char *argv[]) {
	@autoreleasepool {

#ifndef SECOND_PASS
		NSString *src = [NSString stringWithContentsOfFile:@"./marge.obj" encoding:NSUTF8StringEncoding error:nil];
#else
		NSString *src = [NSString stringWithContentsOfFile:@"./blur.obj" encoding:NSUTF8StringEncoding error:nil];
		
#endif
	
		NSArray *lines = [src componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
		
		NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
		
		std::vector<float> v;
		std::vector<unsigned int> f;
		
		float minmax[3][2] = {
			{32767,-32768},
			{32767,-32768},
			{32767,-32768}
		};
		
		for(int k=0; k<[lines count]; k++) {
			NSArray *arr = [lines[k] componentsSeparatedByCharactersInSet:whitespaces];
			if([arr count]>0) {
				if([arr[0] isEqualToString:@"v"]) {
					
					float x = [arr[1] doubleValue];
					float y = [arr[2] doubleValue];
					float z = [arr[3] doubleValue];
					
					if(x<minmax[0][0]) minmax[0][0] = x;
					if(minmax[0][1]<x) minmax[0][1] = x;
					
					if(y<minmax[1][0]) minmax[1][0] = y;
					if(minmax[1][1]<y) minmax[1][1] = y;
					
					if(z<minmax[2][0]) minmax[2][0] = z;
					if(minmax[2][1]<z) minmax[2][1] = z;
					
					v.push_back(x);
					v.push_back(y);
					v.push_back(z);
					v.push_back([arr[4] doubleValue]);
					v.push_back([arr[5] doubleValue]);
					v.push_back([arr[6] doubleValue]);
				}
				else if([arr[0] isEqualToString:@"f"]) {
					f.push_back([arr[1] intValue]-1);
					f.push_back([arr[2] intValue]-1);
					f.push_back([arr[3] intValue]-1);
				}
			}
		}
		
		unsigned int length = v.size()/6;

		unsigned int *use = new unsigned int[length];
		for(int n=0; n<length; n++) use[n] = false;
		std::vector<std::vector<int>> indices;
		
		double then = CFAbsoluteTimeGetCurrent();
		
		float mid[3] = {
			minmax[0][0]+(minmax[0][1]-minmax[0][0])*0.5f,
			minmax[1][0]+(minmax[1][1]-minmax[1][0])*0.5f,
			minmax[2][0]+(minmax[2][1]-minmax[2][0])*0.5f,
		};
		
		NSLog(@"%f,%f,%f",minmax[0][0],mid[0],minmax[0][1]);
		NSLog(@"%f,%f,%f",minmax[1][0],mid[1],minmax[1][1]);
		NSLog(@"%f,%f,%f",minmax[2][0],mid[2],minmax[2][1]);
		
		
		
		std::vector<std::vector<unsigned int>> classification;
		for(int c=0; c<8; c++) classification.push_back({});
		
		
		for(int n=0; n<length; n++) {
		
			float x = v[n*6+0];
			float y = v[n*6+1];
			float z = v[n*6+2];
			
			unsigned int c = 0;
			c|=(x<mid[0])?0:1<<2; 
			c|=(y<mid[1])?0:1<<1; 
			c|=(z<mid[2])?0:1; 
			
			classification[c].push_back(n);
		}
		
		for(unsigned int c=0; c<8; c++) {	
			NSLog(@"%d",classification[c].size());
		}

		for(unsigned int c=0; c<8; c++) {
			std::vector<unsigned int> *tmp = &classification[c];
			for(int n=0; n<tmp->size(); n++) {
				unsigned int p = (*tmp)[n];
				if(!use[p]) {
					use[p] = true;
					float x = v[p*6+0];
					float y = v[p*6+1];
					float z = v[p*6+2];
					indices.push_back({});
					indices[indices.size()-1].push_back(p);
					for(int k=n+1; k<tmp->size(); k++) {
						unsigned int q = (*tmp)[k];
						if(x==v[q*6+0]&&y==v[q*6+1]&&z==v[q*6+2]) {
							use[q] = true;
							indices[indices.size()-1].push_back(q);
						}
					}
				}
			}
		}
		
		for(int n=0; n<length; n++) {
			if(!use[n]) {
				use[n] = true;
				float x = v[n*6+0];
				float y = v[n*6+1];
				float z = v[n*6+2];
				indices.push_back({});
				indices[indices.size()-1].push_back(n);
				for(int k=n+1; k<length; k++) {
					if(x==v[k*6+0]&&y==v[k*6+1]&&z==v[k*6+2]) {
						use[k] = true;
						indices[indices.size()-1].push_back(k);
					}
				}
			}
		}
		
		NSLog(@"%f",CFAbsoluteTimeGetCurrent()-then);
		
		NSLog(@"v.size is %ld",v.size());
		NSLog(@"indices.size is %ld",indices.size());


		std::vector<std::vector<unsigned int>> connection;
		for(int n=0; n<v.size()/3; n++) {
			connection.push_back({});
		}
		
		for(int n=0; n<f.size()/3; n++) {
			
			unsigned int face[3] = {
				f[n*3+0],
				f[n*3+1],
				f[n*3+2]
			};
			
			bool found = false;
			
			
			for(int k=0; k<connection[face[0]].size(); k++) {
				if(connection[face[0]][k]==face[1]) {
					found = true;
					break;
				}
			}
			if(!found) connection[face[0]].push_back(face[1]);
			
			found = false;
			for(int k=0; k<connection[face[0]].size(); k++) {
				if(connection[face[0]][k]==face[2]) {
					found = true;
					break;
				}
			}
			if(!found) connection[face[0]].push_back(face[2]);
			
			found = false;
			for(int k=0; k<connection[face[1]].size(); k++) {
				if(connection[face[1]][k]==face[0]) {
					found = true;
					break;
				}
			}
			if(!found) connection[face[1]].push_back(face[0]);
			
			found = false;
			for(int k=0; k<connection[face[1]].size(); k++) {
				if(connection[face[1]][k]==face[2]) {
					found = true;
					break;
				}
			}
			if(!found) connection[face[1]].push_back(face[2]);
			
			found = false;
			for(int k=0; k<connection[face[2]].size(); k++) {
				if(connection[face[2]][k]==face[0]) {
					found = true;
					break;
				}
			}
			if(!found) connection[face[2]].push_back(face[0]);
			
			found = false;
			for(int k=0; k<connection[face[2]].size(); k++) {
				if(connection[face[2]][k]==face[1]) {
					found = true;
					break;
				}
			}
			if(!found) connection[face[2]].push_back(face[1]);
		}
		
		std::vector<std::vector<int>> group;
		for(int n=0; n<indices.size(); n++) {
		
			group.push_back({});
			
			std::vector<int> *tmp = &indices[n];
			unsigned int len = tmp->size();
			
			for(int k=0; k<len; k++) {
				
				group[n].push_back((*tmp)[k]);
				
				unsigned int list = connection[(*tmp)[k]].size();
				for(int l=0; l<list; l++) {
					
					unsigned int v = connection[(*tmp)[k]][l];
					
					bool found = false;
					for(int g=0; g<group[n].size(); g++) {
						if(group[n][g]==v) {
							found = true;
							break;
						}
					}
					
					if(!found) group[n].push_back(v);

				}
			}
		}
			
		
		//NSLog(@"connection.size is %d",connection.size());
		
		
		
		NSLog(@"%f",CFAbsoluteTimeGetCurrent()-then);


		for(int n=0; n<group.size(); n++) {
			
			float r = 0;
			float g = 0;
			float b = 0;
			
			for(int k=0; k<group[n].size(); k++) {
				r+=v[group[n][k]*6+3];
				g+=v[group[n][k]*6+4];
				b+=v[group[n][k]*6+5];
			}
			
			r/=group[n].size();
			g/=group[n].size();
			b/=group[n].size();
			
			std::vector<int> *tmp = &indices[n];
			for(int k=0; k<tmp->size(); k++) {
				v[indices[n][k]*6+3] = r;
				v[indices[n][k]*6+4] = g;
				v[indices[n][k]*6+5] = b;
			}
		}
		
		
		NSMutableString *obj = [NSMutableString stringWithString:@""];
		
		for(int n=0; n<length; n++) {
			[obj appendString:[NSString stringWithFormat:@"v %0.4f %0.4f %04f %0.4f %0.4f %0.4f\n",v[n*6+0],v[n*6+1],v[n*6+2],v[n*6+3],v[n*6+4],v[n*6+5]]];
		} 
		
		for(int n=0; n<length/6; n++) {
			[obj appendString:[NSString stringWithFormat:@"f %d %d %d\n",1+n*6+0,1+n*6+1,1+n*6+2]];
			[obj appendString:[NSString stringWithFormat:@"f %d %d %d\n",1+n*6+3,1+n*6+4,1+n*6+5]];
		} 
		
#ifndef SECOND_PASS
		[obj writeToFile:@"blur.obj" atomically:YES encoding:NSUTF8StringEncoding error:nil];
#else
		[obj writeToFile:@"blur2.obj" atomically:YES encoding:NSUTF8StringEncoding error:nil];
#endif
		
		
	}
}